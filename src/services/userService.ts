import { injectable } from "tsyringe";
import { Services } from "./services";
import { User, UserDocument } from "../models/user";

@injectable()
export class UserServices extends Services<UserDocument> {
  constructor() {
    super(User);
  }

  getUser = async (userId: string) => {
    this.validateObjectId(userId);
    const user = await this.model
      .findById(userId)
      .select("email fullName image phone provider");

    if (!user) {
      throw new Error("User not found");
    }

    return user;
  };

  updateUser = async (userId: string, updateData: Partial<UserDocument>) => {
    this.validateObjectId(userId);
    const updatedUser = await this.model
      .findByIdAndUpdate(
        userId,
        { $set: updateData },
        { new: true, runValidators: true } // new: true returns updated doc
      )
      .select("email fullName image phone provider");
    if (!updatedUser) {
      throw new Error("User not found");
    }

    return updatedUser;
  };

  deleteUser = async (userId: string) => {
    this.validateObjectId(userId);

    const deletedUser = await User.findByIdAndDelete(userId).select(
      "-password -tokenPackages"
    );

    if (!deletedUser) {
      throw new Error("User not found");
    }

    return deletedUser;
  };

  getAllUsers = async (page = 1, limit = 10) => {
    const skip = (page - 1) * limit;

    const users = await User.find()
      .select("-password -tokenPackages")
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments();

    return {
      users,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };
  };

  changeUserStatus = async (userId: string, isActive: boolean) => {
    this.validateObjectId(userId);

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $set: { isActive } },
      { new: true, runValidators: true }
    ).select("-password -tokenPackages");

    if (!updatedUser) {
      throw new Error("User not found");
    }

    return updatedUser;
  };
}
