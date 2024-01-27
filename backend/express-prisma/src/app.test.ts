import request from "supertest";
import app from "./app";
import { describe, test, expect, afterAll } from "@jest/globals";
import { PrismaClient } from "@prisma/client";

/* 
  チェック観点：
    メソッドごと
    パスごと
    データ条件
    正常系・異常系
*/

const prisma = new PrismaClient();
afterAll(async () => {
  await prisma.task.deleteMany({});
});

describe("health check", () => {
  test("return 200 OK", async () => {
    const response = await request(app).get("/api/health");
    expect(response.status).toEqual(200);
  });
});

describe("list tasks when empty data", () => {
  test("empty data", async () => {
    const response = await request(app).get("/api/tasks");
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(200);
    expect(response.body.data.length).toBe(0);
  });
});

let task_id: number;
describe("create, list, get tasks", () => {
  test("create data", async () => {
    const data = {
      summary: "s1",
      description: "d1",
      status: "not_started_yet",
    };
    const response = await request(app).post("/api/tasks").send(data);
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(201);
    task_id = response.body.data["id"];
  });

  test("list 1 data", async () => {
    const response = await request(app).get("/api/tasks");
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(200);
    expect(response.body.data.length).toBe(1);
  });

  test("get 1 data", async () => {
    const response = await request(app).get(`/api/tasks/${task_id}`);
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(200);
    expect(response.body.data["id"]).toBe(task_id);
  });
});

describe("update and delete tasks", () => {
  const data = {
    summary: "s1 updated",
    description: "d1 updated",
    status: "in_progress",
  };

  test("update task", async () => {
    const response = await request(app).put(`/api/tasks/${task_id}`).send(data);
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(200);
  });

  test("get 1 updated data", async () => {
    const response = await request(app).get(`/api/tasks/${task_id}`);
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(200);
    expect(response.body.data["id"]).toBe(task_id);
    expect(response.body.data["summary"]).toBe(data.summary);
    expect(response.body.data["description"]).toBe(data.description);
    expect(response.body.data["status"]).toBe(data.status);
  });

  test("delete data", async () => {
    const response = await request(app).delete(`/api/tasks/${task_id}`);
    expect(response.headers["content-type"]).toMatch(
      new RegExp("application/json"),
    );
    expect(response.status).toEqual(200);
    expect(response.body.data["id"]).toBe(task_id);
  });
});
