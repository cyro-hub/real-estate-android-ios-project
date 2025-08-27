import passport from "passport";
import { Strategy as LocalStrategy } from "passport-local";
import { User } from "../models/user";

passport.use(
  new LocalStrategy(
    { usernameField: "email" },
    async (email, password, done) => {
      try {
        const user = await User.findOne({ email });
        if (!user) return done(null, false, { message: "User not found" });
        // if (!user.isVerified)
        //   return done(null, false, { message: "Email not verified" });

        if (user.provider === "google")
          return done(null, false, {
            message: "Please sign up with google account",
          });

        const isMatch = await user.comparePassword(password);
        if (!isMatch) return done(null, false, { message: "Invalid password" });

        return done(null, user);
      } catch (err) {
        return done(err);
      }
    }
  )
);

export default passport;
