import { MongoClient } from "mongodb";
import { Schedule } from "./models.js";

const WORKOUTS_COLLECTION = "workouts";
const MONGODB_URI = process.env.MONGODB_URI || "mongodb://localhost:27017";
const DB_NAME = process.env.MONGODB_DB_NAME || "workout-app";

let client: MongoClient = new MongoClient(MONGODB_URI);
let schedulesCollection = client
  .db(DB_NAME)
  .collection<Schedule>(WORKOUTS_COLLECTION);

export const getWorkoutDb = (): WorkoutDb => {
  return {
    saveSchedule: async (schedule: Schedule) => {
      console.log(`Saving schedule: id: ${schedule.id} name: ${schedule.name}`);
      let result = await schedulesCollection.replaceOne(
        { id: schedule.id },
        schedule,
        { upsert: true },
      );
    },
    getScheduleByName: async (name: string) => {
      const schedule = await schedulesCollection.findOne({ name });
      return schedule || undefined;
    },
    getSchedules: async () => {
      return await schedulesCollection.find({}).toArray();
    },
    getScheduleById: async (id: string) => {
      const schedule = await schedulesCollection.findOne({ id });
      return schedule || undefined;
    },
  };
};

export interface WorkoutDb {
  saveSchedule(schedule: Schedule): Promise<void>;

  getScheduleByName(name: string): Promise<Schedule | undefined>;

  getSchedules(): Promise<Schedule[]>;

  getScheduleById(id: string): Promise<Schedule | undefined>;
}
