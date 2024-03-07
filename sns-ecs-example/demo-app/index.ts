import Hatchet, { Context, Workflow } from "@hatchet-dev/typescript-sdk";

const hatchet = Hatchet.init();

const workflow: Workflow = {
  id: "sns-event-workflow",
  description: "Workflow that responds to SNS events",
  on: {
    event: "sns-event",
  },
  steps: [
    {
      name: "step1",
      retries: 5,
      run: async (ctx: Context<any, any>) => {
        ctx.log(
          "starting step1 with the following input: " +
            JSON.stringify(ctx.workflowInput())
        );

        return {
          result: "success!",
        };
      },
    },
  ],
};

async function main() {
  const w = await hatchet.worker("sns-worker");
  await w.registerWorkflow(workflow);
  w.start();
}

main();
