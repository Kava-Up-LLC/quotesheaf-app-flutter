export const handler = async (ctx) => {
  const id = ctx.req?.query?.id ?? ctx.req?.id ?? "";
  return {
    status: 200,
    headers: { "Content-Type": "text/html; charset=utf-8" },
    body: "<h1>Invoice " + id + "</h1>",
  };
};
