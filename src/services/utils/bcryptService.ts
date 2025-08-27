import { injectable } from "tsyringe";
import bcrypt from "bcryptjs";

@injectable()
export class Bcrypt {
  async hash(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
  }

  // Compares a password with a hashed password
  async compare(password: string, hashedPassword: string): Promise<boolean> {
    return await bcrypt.compare(password, hashedPassword);
  }
}
