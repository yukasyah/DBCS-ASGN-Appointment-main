// Check if user is authenticated
export function isAuthenticated(req, res, next) {
    if (req.session.user) {
        next();
    } else {
        res.redirect('/');
    }
}

// Role-based middleware
export function isDoctor(req, res, next) {
    if (req.session.user && req.session.user.role === 'doctor') {
        next();
    } else {
        res.status(403).send('Access denied. Doctors only.');
    }
}

export function isClerk(req, res, next) {
    if (req.session.user && req.session.user.role === 'clerk') {
        next();
    } else {
        res.status(403).send('Access denied. Clerks only.');
    }
}

export function isPatient(req, res, next) {
    if (req.session.user && req.session.user.role === 'patient') {
        next();
    } else {
        res.status(403).send('Access denied. Patients only.');
    }
}

// Redirect to appropriate dashboard based on role
export function redirectToDashboard(req, res, next) {
    if (req.session.user) {
        switch (req.session.user.role) {
            case 'doctor':
                res.redirect('/doctor/dashboard');
                break;
            case 'clerk':
                res.redirect('/clerk/dashboard');
                break;
            case 'patient':
                res.redirect('/patient/dashboard');
                break;
            default:
                res.redirect('/');
        }
    } else {
        next();
    }
}
