import { Router } from "express";
import { injectable } from "tsyringe";
import AuthController from "../controllers/authController";
import TokenController from "../controllers/tokenController";
import { authenticate } from "passport";

@injectable()
export default class TokenRouter {
  public tokenRouter: Router;
  constructor(
    private tokenController: TokenController,
    private authController: AuthController
  ) {
    this.tokenRouter = Router();
    this.initRoutes();
  }

  private initRoutes(): void {
    this.tokenRouter.post(
      "/",
      this.authController.authenticate,
      this.tokenController.addToken
    );
  }
}
