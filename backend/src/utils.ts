import { createHash as hash } from "crypto";

export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}

export function createHash(dataToHash: Object) {
  const json = JSON.stringify(dataToHash);
  return hash("sha1").update(json).digest("hex");
}
