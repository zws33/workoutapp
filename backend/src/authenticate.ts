import 'dotenv/config';
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import {Request, Response, NextFunction} from 'express';

let credentials = process.env.GOOGLE_CREDENTIALS;
if (!credentials) {
  throw new Error('GOOGLE_CREDENTIALS environment variable not set');
}
initializeApp({
  credential: cert(credentials)
});

/**
 * Middleware to verify Google OAuth tokens
 */
export const verifyToken = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (process.env.NODE_ENV === 'production') {
    try {
      // Get the token from the Authorization header
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({error: 'Unauthorized: No token provided'});
      }

      const token = authHeader.split(' ')[1];

      const decodedToken = await getAuth().verifyIdToken(token);

      if (!decodedToken) {
        return res.status(401).json({error: 'Unauthorized: Invalid token'});
      }

      next();
    } catch (error) {
      console.error('Token verification failed:', error);
      return res.status(401).json({error: 'Unauthorized: Invalid token'});
    }
  } else {
    next();
  }
};

export async function authenticateUser(req: Request, res: Response, next: NextFunction) {
  if (process.env.NODE_ENV === 'production') {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).send('Unauthorized: No token provided or invalid format.');
      }
      const idToken = authHeader.split('Bearer ')[1]; // Extract the token string

      try {
        await getAuth().verifyIdToken(idToken);
        next();
      } catch (error) {
        // 5. If verification fails, the token is invalid (expired, tampered, etc.)
        console.error('Error verifying ID token:', error);
        return res.status(401).send('Unauthorized: Invalid or expired token.');
      }
    } catch (error) {
      console.error('Token verification failed:', error);
      return res.status(401).json({error: 'Unauthorized: Invalid token'});
    }
  } else {
    next();
  }
}
