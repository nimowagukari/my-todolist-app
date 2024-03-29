import express from "express";
import { PrismaClient } from "@prisma/client";

const app = express();
const logger = (
  req: express.Request,
  _: express.Response,
  next: express.NextFunction,
) => {
  const logLine = {
    timestamp: new Date().toISOString(),
    path: req.url,
    method: req.method,
  };
  console.log(JSON.stringify(logLine));
  next();
};
const prisma = new PrismaClient();

app.set("strict routing", true);
app.use(express.json());
app.use(logger);

app.get("/api/health", async (req, res) => {
  res.status(200).json({ method: req.method, url: req.url });
});

app.get("/api/tasks", async (req, res) => {
  try {
    const tasks = await prisma.task.findMany();
    res.status(200).json({ method: req.method, url: req.url, data: tasks });
  } catch (e) {
    res.status(500).json({ method: req.method, url: req.url, error: e });
  }
});

app.post("/api/tasks", async (req, res) => {
  try {
    const task = await prisma.task.create({
      data: req.body,
    });
    res.status(201).json({ method: req.method, url: req.url, data: task });
  } catch (e) {
    res.status(500).json({ method: req.method, url: req.url, error: e });
  }
});

app.get("/api/tasks/:taskId(\\d+)", async (req, res) => {
  try {
    const task = await prisma.task.findUniqueOrThrow({
      where: { id: Number(req.params["taskId"]) },
    });
    res.status(200).json({ method: req.method, url: req.url, data: task });
  } catch (e) {
    res.status(500).json({ method: req.method, url: req.url, error: e });
  }
});

app.put("/api/tasks/:taskId(\\d+)", async (req, res) => {
  try {
    const task = await prisma.task.update({
      where: { id: Number(req.params["taskId"]) },
      data: req.body,
    });
    res.status(200).json({ method: req.method, url: req.url, data: task });
  } catch (e) {
    res.status(500).json({ method: req.method, url: req.url, error: e });
  }
});

app.delete("/api/tasks/:taskId(\\d+)", async (req, res) => {
  try {
    const task = await prisma.task.delete({
      where: { id: Number(req.params["taskId"]) },
    });
    res.status(200).json({ method: req.method, url: req.url, data: task });
  } catch (e) {
    res.status(500).json({ method: req.method, url: req.url, error: e });
  }
});

export default app;
