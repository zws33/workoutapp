import admin from 'firebase-admin';
import { Request, Response, NextFunction } from 'express';

/**
 * Middleware to verify Google OAuth tokens
 */
export const verifyToken = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const isProd = Deno.env.get('NODE_ENV') === 'production';
  if (isProd) {
    try {
      // Get the token from the Authorization header
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res
          .status(401)
          .json({ error: 'Unauthorized: No token provided' });
      }

      const token = authHeader.split(' ')[1];

      const decodedToken = await admin.auth().verifyIdToken(token);

      if (!decodedToken) {
        return res.status(401).json({ error: 'Unauthorized: Invalid token' });
      }

      next();
    } catch (error) {
      console.error('Token verification failed:', error);
      return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }
  } else {
    // In development mode, skip token verification
    next();
  }
};
