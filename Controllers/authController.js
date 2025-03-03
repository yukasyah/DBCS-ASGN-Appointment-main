import bcrypt from 'bcryptjs';
import { queryAuthDbNotEmp, queryAuthDbEmp, queryApptDbPat } from '../db.js';
import validator from 'validator';
// Here no need query on ApptDB from doctor and clerk because admin will enter the information for them.


const isValidEmail = (email) => {
  return validator.isEmail(email);
};

const isValidPassword = (password) => {
  const regex = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
  return regex.test(password);
};

// Render login pages
export async function renderDoctorLoginPage(req, res) {
  try {
    console.log('Rendering doctor login page');
    res.render('doctor/login/index', { error: null });
  } catch (err) {
    console.error('Error rendering doctor login:', err);
    res.status(500).send('Error rendering page: ' + err.message);
  }
}

export async function renderClerkLoginPage(req, res) {
  try {
    console.log('Rendering clerk login page');
    res.render('clerk/login/index', { error: null });
  } catch (err) {
    console.error('Error rendering clerk login:', err);
    res.status(500).send('Error rendering page: ' + err.message);
  }
}

export async function renderPatientLoginPage(req, res) {
  try {
    console.log('Rendering patient login page');
    res.render('patient/login/index', { error: null });
  } catch (err) {
    console.error('Error rendering patient login:', err);
    res.status(500).send('Error rendering page: ' + err.message);
  }
}

//Render Signup pages
export async function renderPatientSignupPage(req, res) {
  try {
    console.log('Rendering patient signup page');
    res.render('patient/signup/index', { error: null, bloodTypes: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] });
  } catch (err) {
    console.error('Error rendering patient signup:', err);
    res.status(500).send('Error rendering page: ' + err.message);
  }
}

export async function renderDoctorSignupPage(req, res) {
  try {
    console.log('Rendering doctor signup page');
    res.render('doctor/signup/index', { error: null });
  } catch (err) {
    console.error('Error rendering doctor signup:', err);
    res.status(500).send('Error rendering page: ' + err.message);
  }
}

export async function renderClerkSignupPage(req, res) {
  try {
    console.log('Rendering clerk signup page');
    res.render('clerk/signup/index', { error: null });
  } catch (err) {
    console.error('Error rendering clerk signup:', err);
    res.status(500).send('Error rendering page: ' + err.message);
  }
}

// Security checks on DB-end
export async function EmploginHandler(req, res, roleID, role) {
  const { email, password } = req.body;
  //Debug
  //console.log('Request body:', req.body);
  //console.log(`Login attempt for role: ${role}, roleID: ${roleID}`);
  //console.log(`Email: ${email}, RoleID: ${roleID}`);

  const query = `
        EXEC [Auth].[AuthenticateUser] @Email = @Email, @RoleID = @RoleID
    `;
  const params = { Email: email, RoleID: roleID };

  try {
    console.log('Executing query with parameters:', params);
    const result = await queryAuthDbEmp(query, params);

    //Debug
    //console.log('Query result:', result);

    if (result && result[0] && result[0].ErrorMessage) {
      console.log(`Authentication error: ${result[0].ErrorMessage}`);
      return res.render(`${role}/login/index`, { error: result[0].ErrorMessage });
    }

    if (result && result.length > 0) {
      const user = result[0];

      //Debug
      //console.log('Entered Password: ', password);
      //console.log('Stored Password (Hashed): ', user.Password);

      const match = await bcrypt.compare(password, user.Password);

      if (match) {
        req.session.user = { id: user.UserID, email: user.Email, role: role };
        console.log('Query result:', result); // Make sure this shows the Email field correctly

        console.log(`Login successful for ${role} with email: ${email}`);
        return res.redirect(`/${role}/dashboard`);
      }
      else {
        console.log('Password mismatch');
      }
    } else {
      console.log('No user found or invalid credentials');
    }

    res.render(`${role}/login/index`, { error: 'Invalid credentials' });
  } catch (err) {
    console.error(`Error during ${role} login:`, err);
    res.render(`${role}/login/index`, { error: 'Internal server error' });
  }
}

export async function NotEmploginHandler(req, res, roleID, role) {
  const { email, password } = req.body;
  //Debug
  //console.log('Request body:', req.body);
  //console.log(`Login attempt for role: ${role}, roleID: ${roleID}`);
  //console.log(`Email: ${email}, RoleID: ${roleID}`);

  const query = `
      EXEC [Auth].[AuthenticateUser] @Email = @Email, @RoleID = @RoleID
  `;
  const params = { Email: email, RoleID: roleID };

  try {
    console.log('Executing query with parameters:', params);
    const result = await queryAuthDbNotEmp(query, params);

    //Debug
    //console.log('Query result:', result);

    if (result && result[0] && result[0].ErrorMessage) {
      console.log(`Authentication error: ${result[0].ErrorMessage}`);
      return res.render(`${role}/login/index`, { error: result[0].ErrorMessage });
    }

    if (result && result.length > 0) {
      const user = result[0];

      //Debug
      //console.log('Entered Password: ', password);
      //console.log('Stored Password (Hashed): ', user.Password);

      const match = await bcrypt.compare(password, user.Password);

      if (match) {

        req.session.user = {
          id: user.UserID,
          email: user.Email,
          role: role
        };

        console.log(`Login successful for ${role} with email: ${email}`);
        return res.redirect(`/${role}/dashboard`);
      } else {
        console.log('Password mismatch');
      }
    } else {
      console.log('No user found or invalid credentials');
    }

    res.render(`${role}/login/index`, { error: 'Invalid credentials' });
  } catch (err) {
    console.error(`Error during ${role} login:`, err);
    res.render(`${role}/login/index`, { error: 'Internal server error' });
  }
}

// Signup Handlers
export async function doctorSignup(req, res) {
  const { email, securityCode, password } = req.body;
  console.log('Doctor signup attempt:', email);

  const emailCheckQuery = `EXEC [Auth].[CheckEmailExists] @Email = @Email`;
  const emailCheckParams = { Email: email };

  try {
    const emailCheckResult = await queryAuthDbEmp(emailCheckQuery, emailCheckParams);

    if (!isValidPassword(password)) {
      return res.render('doctor/signup/index', { error: 'Password must be at least 8 characters long and contain a mix of uppercase letters, numbers, and special characters.' });
    }

    if (emailCheckResult && emailCheckResult[0].count > 0) {
      console.log('Email already exists');
      return res.render('doctor/signup/index', { error: 'Email already registered. Please use a different email.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const roleID = 1;
    const activationParams = { Email: email };
    const activationQuery = `EXEC [Emp].[CheckAccountActivation] @Email = @Email`;
    const activationResult = await queryAuthDbEmp(activationQuery, activationParams);

    if (activationResult[0].RoleID !== 1) {
      console.log('This signup page is only for Doctors');
      return res.render('doctor/signup/index', { error: 'This signup page is only for Doctors. Clerks cannot sign up here.' });
    }

    if (!activationResult || activationResult.length === 0) {
      console.log('Invalid or expired security code');
      return res.render('doctor/signup/index', { error: 'Invalid or expired security code.' });
    }

    if (securityCode !== activationResult[0].SecurityCode) {
      console.log('Invalid security code');
      return res.render('doctor/signup/index', { error: 'Invalid security code.' });
    }

    const userAccountParams = {
      Email: email,
      Password: hashedPassword,
      RoleID: roleID,
      IsActive: 1,
      CreatedAt: new Date(),
      UpdatedAt: new Date()
    };

    const authQuery = `EXEC [Auth].[InsertUserAccount] 
          @Email = @Email, 
          @Password = @Password, 
          @RoleID = @RoleID, 
          @IsActive = @IsActive, 
          @CreatedAt = @CreatedAt, 
          @UpdatedAt = @UpdatedAt`;

    await queryAuthDbEmp(authQuery, userAccountParams);

    const activationRecord = activationResult[0];
    const updateActivationParams = { PendingID: activationRecord.PendingID };
    const updateActivationQuery = `EXEC [Emp].[UpdateActivationCode] @PendingID = @PendingID`;
    await queryAuthDbEmp(updateActivationQuery, updateActivationParams);

    console.log('Doctor signup successful:', email);
    res.redirect('/doctor/login');
  } catch (err) {
    console.error('Error during doctor registration:', err);
    res.render('doctor/signup/index', { error: 'An error occurred during registration. Please try again.' });
  }
}

export async function clerkSignup(req, res) {
  const { email, securityCode, password } = req.body;
  console.log('Clerk signup attempt:', email);

  const emailCheckQuery = `EXEC [Auth].[CheckEmailExists] @Email = @Email`;
  const emailCheckParams = { Email: email };

  try {
    const emailCheckResult = await queryAuthDbEmp(emailCheckQuery, emailCheckParams);

    if (!isValidPassword(password)) {
      return res.render('clerk/signup/index', { error: 'Password must be at least 8 characters long and contain a mix of uppercase letters, numbers, and special characters.' });
    }

    if (emailCheckResult && emailCheckResult[0].count > 0) {
      console.log('Email already exists');
      return res.render('clerk/signup/index', { error: 'Email already registered. Please use a different email.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const roleID = 2;
    const activationParams = { Email: email };
    const activationQuery = `EXEC [Emp].[CheckAccountActivation] @Email = @Email`;
    const activationResult = await queryAuthDbEmp(activationQuery, activationParams);

    if (activationResult[0].RoleID !== 2) {
      console.log('This signup page is only for Clerks');
      return res.render('clerk/signup/index', { error: 'This signup page is only for Clerks. Doctors cannot sign up here.' });
    }

    if (!activationResult || activationResult.length === 0) {
      console.log('Invalid or expired security code');
      return res.render('clerk/signup/index', { error: 'Invalid or expired security code.' });
    }

    if (securityCode !== activationResult[0].SecurityCode) {
      console.log('Invalid security code');
      return res.render('clerk/signup/index', { error: 'Invalid security code.' });
    }

    const userAccountParams = {
      Email: email,
      Password: hashedPassword,
      RoleID: roleID,
      IsActive: 1,
      CreatedAt: new Date(),
      UpdatedAt: new Date()
    };

    const authQuery = `EXEC [Auth].[InsertUserAccount] 
          @Email = @Email, 
          @Password = @Password, 
          @RoleID = @RoleID, 
          @IsActive = @IsActive, 
          @CreatedAt = @CreatedAt, 
          @UpdatedAt = @UpdatedAt`;

    await queryAuthDbEmp(authQuery, userAccountParams);

    const activationRecord = activationResult[0];
    const updateActivationParams = { PendingID: activationRecord.PendingID };
    const updateActivationQuery = `EXEC [Emp].[UpdateActivationCode] @PendingID = @PendingID`;
    await queryAuthDbEmp(updateActivationQuery, updateActivationParams);

    console.log('Clerk signup successful:', email);
    res.redirect('/clerk/login');
  } catch (err) {
    console.error('Error during clerk registration:', err);
    res.render('clerk/signup/index', { error: 'An error occurred during registration. Please try again.' });
  }
}

export async function patientSignup(req, res) {
  const { email, fullName, dateOfBirth, phone, password, ic, gender, address, medicalInsuranceProvider, height, weight, allergies, bloodType, chronicCondition, privacyPolicy } = req.body;

  if (!privacyPolicy) {
    return res.render('patient/signup/index', { error: 'You must agree to the privacy policy to register.' });
  }

  const emailCheckQuery = `EXEC [Auth].[CheckEmailExists] @Email = @Email`;
  const emailCheckParams = { Email: email };

  try {
    const emailCheckResult = await queryAuthDbNotEmp(emailCheckQuery, emailCheckParams);

    if (!isValidEmail(email)) {
      return res.render('patient/signup/index', { error: 'Invalid email format.' });
    }

    if (!isValidPassword(password)) {
      return res.render('patient/signup/index', { error: 'Password must be at least 8 characters long and contain a mix of uppercase letters, numbers, and special characters.' });
    }

    if (emailCheckResult && emailCheckResult[0].count > 0) {
      console.log('Email already exists');
      return res.render('patient/signup/index', { error: 'Email already registered. Please use a different email.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const userAccountParams = {
      Email: email,
      Password: hashedPassword,
      RoleID: 3,
      IsActive: 1,
      CreatedAt: new Date(),
      UpdatedAt: new Date()
    };

    const patientParams = {
      PatientFullName: fullName,
      Email: email,
      IC: ic,
      DOB: dateOfBirth,
      Gender: gender,
      PatientPhoneNum: phone,
      Address: address,
      MedicalInsuranceProvider: medicalInsuranceProvider
    };

    const authQuery = `EXEC [Auth].[InsertUserAccount] 
          @Email = @Email, 
          @Password = @Password, 
          @RoleID = @RoleID, 
          @IsActive = @IsActive, 
          @CreatedAt = @CreatedAt, 
          @UpdatedAt = @UpdatedAt`;

    await queryAuthDbNotEmp(authQuery, userAccountParams);

    const patientQuery = `EXEC [Patient].[InsertPatient] 
          @PatientFullName = @PatientFullName, 
          @Email = @Email, 
          @IC = @IC, 
          @DOB = @DOB, 
          @Gender = @Gender, 
          @PatientPhoneNum = @PatientPhoneNum, 
          @Address = @Address, 
          @MedicalInsuranceProvider = @MedicalInsuranceProvider`;

    const patientResult = await queryApptDbPat(patientQuery, patientParams);

    const patientID = patientResult && patientResult.length > 0 ? patientResult[0].PatientID : null;

    if (!patientID) {
      throw new Error('Failed to retrieve PatientID after insertion');
    }

    const medicalProfileParams = {
      PatientID: patientID,
      Height: height,
      Weight: weight,
      BloodType: bloodType,
      Allergies: allergies,
      ChronicCondition: chronicCondition
    };

    const medicalProfileQuery = `EXEC [Patient].[InsertMedicalProfile] 
          @PatientID = @PatientID, 
          @Height = @Height, 
          @Weight = @Weight, 
          @BloodType = @BloodType, 
          @Allergies = @Allergies, 
          @ChronicCondition = @ChronicCondition`;

    await queryApptDbPat(medicalProfileQuery, medicalProfileParams);

    res.redirect('/patient/login');
  } catch (err) {
    console.error('Error during patient signup:', err);
    res.render('patient/signup/index', { error: 'Error creating account. Please try again.' });
  }
}

// Handle logout
export function logout(req, res) {
  req.session.destroy((err) => {
    if (err) {
      console.error('Error during logout:', err);
      return res.status(500).send('Error during logout');
    }
    res.redirect('/');
  });
}
