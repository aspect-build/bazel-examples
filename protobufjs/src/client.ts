import { Weather, Forecast, Wind } from './weather';
import * as grpc from '@grpc/grpc-js';
import * as pbjs from 'protobufjs';

const WeatherClient = grpc.makeGenericClientConstructor({}, 'Weather');

const client = new WeatherClient(
  '0.0.0.0:1334',
  grpc.credentials.createInsecure()
);

const transport: pbjs.RPCImpl = function (method, data, callback) {
  client.makeUnaryRequest(
    `/Weather/${method.name}`,
    (arg) => Buffer.from(arg),
    (arg) => arg,
    data,
    callback
  );
};

const weather = Weather.create(transport, false, false);

weather
  .getForecast(Forecast.Request.create({ cityCode: 1, countryCode: 0 }))
  .then((forecast) => {
    console.log(`Forecast`);
    console.log(
      `Temperature ${forecast.temperature?.low}°C LOW / ${forecast.temperature?.high}°C HIGH`
    );
    console.log(
      `Wind direction is ${Wind.Direction[forecast.wind!.direction!]} at ${
        forecast.wind?.speed
      } km/h`
    );
  });
