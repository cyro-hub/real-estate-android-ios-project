import { Router } from "express";
import { injectable } from "tsyringe";
import AuthController from "../controllers/authController";

@injectable()
export default class AuthRouter {
  public authRouter: Router;
  constructor(private authController: AuthController) {
    this.authRouter = Router();
    this.initRoutes();
  }

  private initRoutes(): void {
    this.authRouter.route("/").post(this.authController.login);
    this.authRouter.route("/register").post(this.authController.register);
    this.authRouter.route("/google").post(this.authController.loginWithGoogle);
    this.authRouter
      .route("/change-password")
      .put(
        this.authController.authenticate,
        this.authController.changePassword
      );
    this.authRouter.route("/refresh").post(this.authController.refreshToken);
  }
}
