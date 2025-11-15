// // Backend/functions/src/fc-handler.ts
// import { api } from './index';

// export const handler = (req: any, res: any, context: any) => {
//   res.setHeader('x-powered-by', 'GlitripAI');
//   return (api as any)(req, res, context);
// };
import FCExpress from '@webserverless/fc-express';
import { api } from './index';

const server = new FCExpress.Server(api);

type HttpTriggerArgs = [req: any, res: any, context: any];
type ApiGatewayArgs = [event: any, context: any, callback: any];

export const handler = (...args: any[]) => {
  if (args.length >= 3 && (typeof args[0] === 'string' || Buffer.isBuffer(args[0]))) {
    const [event, context, callback] = args as ApiGatewayArgs;
    return server.proxy(event, context, callback);
  }

  const [req, res, context] = args as HttpTriggerArgs;
  return server.httpProxy(req, res, context);
};
