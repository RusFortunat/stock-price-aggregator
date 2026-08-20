

export const handler = async (event: unknown) => {
  console.log("Event:", JSON.stringify(event));

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from ingestion lambda!",
    }),
  };
};