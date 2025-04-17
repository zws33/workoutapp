import { google } from 'googleapis';
import { OAuth2Client } from 'google-auth-library';
import { Request, Response, NextFunction } from 'express';

export const oauth2Client: OAuth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET
);

export interface AuthenticatedRequest extends Request {
  user?: {
    userId: string;
    email: string;
    name?: string;
    picture?: string;
  };
}

/**
 * Middleware to verify Google OAuth tokens
 */
export const verifyGoogleToken = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    // Get the token from the Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized: No token provided' });
    }

    const token = authHeader.split(' ')[1];

    // Verify the token
    const ticket = await oauth2Client.verifyIdToken({
      idToken: token,
      audience: process.env.APP_CLIENT_ID,
    });

    const payload = ticket.getPayload();

    if (!payload) {
      return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }

    // Add user info to the request object
    req.user = {
      userId: payload.sub, // Google's unique identifier for the user
      email: payload.email || '',
      name: payload.name,
      picture: payload.picture,
    };

    // Continue to the actual endpoint handler
    next();
  } catch (error) {
    console.error('Token verification failed:', error);
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
};
