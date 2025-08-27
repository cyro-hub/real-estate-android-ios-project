import { Router } from "express";
import { injectable } from "tsyringe";
import UserController from "../controllers/userController";

@injectable()
export default class UserRouter {
  public userRouter: Router;
  constructor(private userController: UserController) {
    this.userRouter = Router();
    this.initRoutes();
  }

  private initRoutes(): void {
    this.userRouter.route("/").get(this.userController.getUser);
    this.userRouter.route("/").put(this.userController.updateUser);
  }
}
