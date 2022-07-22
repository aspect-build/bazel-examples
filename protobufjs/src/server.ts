import { Weather, Forecast, Wind } from './weather';
import * as grpc from '@grpc/grpc-js';
import * as pbjs from 'protobufjs';

// Unfortunately protobufjs does not generate service definitions that is compatible with grpc.
// Hence we have to do it ourselves.
// See: https://github.com/protobufjs/protobuf.js/issues/1381
const WeatherServiceDefiniton: grpc.ServiceDefinition = {
  GetForecast: {
    path: '/Weather/GetForecast',
    requestStream: false,
    responseStream: false,
    requestSerialize: (message: Forecast.Request) =>
      Buffer.from(Forecast.Request.encode(message).finish()),
    requestDeserialize: (bytes: Buffer) =>
      Forecast.Request.decode(new Uint8Array(bytes)),
    responseSerialize: (message: Forecast) =>
      Buffer.from(Forecast.encode(message).finish()),
    responseDeserialize: (bytes: Buffer) =>
      Forecast.decode(new Uint8Array(bytes)),
  },
};

const WeatherService = { GetForecast: GetForecast };

function GetForecast(
  call: grpc.ServerUnaryCall<Forecast.Request, Forecast>,
  callback: grpc.requestCallback<Forecast>
) {
  console.log(
    `Get forecast for city: ${call.request.cityCode} / country: ${call.request.countryCode}`
  );

  callback(
    null,
    Forecast.create({
      temperature: {
        high: 32,
        low: 27,
      },
      wind: {
        direction: Wind.Direction.North,
        speed: 10,
      },
    })
  );
}

const server = new grpc.Server();
server.addService(WeatherServiceDefiniton, WeatherService);
server.bindAsync(
  '0.0.0.0:1334',
  grpc.ServerCredentials.createInsecure(),
  (err) => {
    if (err) {
      return console.error(err);
    }

    server.start();
    console.log(`Server is listening on 0.0.0.0:1334`);
  }
);
