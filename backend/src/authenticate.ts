import "dotenv/config";
import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { Request, Response, NextFunction } from "express";
import fs from "fs";

const raw = fs.readFileSync("./secrets/service-account.json", "utf8");
const credentials = JSON.parse(raw);
if (!credentials) {
  throw new Error("GOOGLE_CREDENTIALS environment variable not set");
}

initializeApp({
  credential: cert(credentials),
});

export async function authenticateUser(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  if (process.env.NODE_ENV === "production") {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res
          .status(401)
          .send("Unauthorized: No token provided or invalid format.");
      }
      const idToken = authHeader.split("Bearer ")[1]; // Extract the token string

      try {
        await getAuth().verifyIdToken(idToken);
        next();
      } catch (error) {
        console.error("Error verifying ID token:", error);
        return res.status(401).send("Unauthorized: Invalid or expired token.");
      }
    } catch (error) {
      console.error("Token verification failed:", error);
      return res.status(401).json({ error: "Unauthorized: Invalid token" });
    }
  } else {
    next();
  }
}
