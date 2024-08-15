import type { LogMessage } from '../schema/logger_pb';

class ServerLogs {
  getServerLogs(): Promise<Array<LogMessage>> {
    return fetch('http://localhost:8081')
      .then((response) => this.checkStatus(response))
      .then((response) =>
        this.parseJSON(response)
          .then((response) => {
            return Promise.resolve(this.displayServerLogs(response));
          })
          .catch((error) => this.throwError(error))
      );
  }

  private checkStatus(response: Response): Promise<Response> {
    console.log('in check status');
    if (response.status >= 200 && response.status < 300) {
      return Promise.resolve(response);
    } else {
      let error = new Error(response.statusText);
      throw error;
    }
  }

  private parseJSON(response: Response): Promise<Response> {
    console.log('in parse json');
    return response.json();
  }

  private timestampToString(timestamp): String {
    // https://stackoverflow.com/questions/847185/convert-a-unix-timestamp-to-time-in-javascript
    var date = new Date(timestamp * 1000);
    var hours = date.getHours();
    var minutes = '0' + date.getMinutes();
    var seconds = '0' + date.getSeconds();
    var formattedTime =
      hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
    return formattedTime;
  }

  private displayServerLogs(data: Response) {
    console.log('in display');

    const el: HTMLElement = document.getElementById('log_results');
    el.innerHTML = '';

    var jsonData = JSON.parse(JSON.stringify(data));
    for (var i = 0; i < jsonData.length; i++) {
      var logElement: HTMLDivElement = document.createElement('div');

      var divHTML = '';
      divHTML += "<b>message:</b> '" + jsonData[i].message;
      divHTML +=
        "' received at <b>time:</b> " +
        this.timestampToString(jsonData[i].time);
      logElement.innerHTML = divHTML;

      el.appendChild(logElement);
      console.log(jsonData[i]);
    }

    document.body.appendChild(el);

    return undefined;
  }

  private throwError(error) {
    const el: HTMLElement = document.getElementById('log_results');
    el.innerHTML = 'No logs found, sorry. Try again once the server has logs?';
    console.log(error);
    return Promise.reject(error);
  }
}

let serverLogs = new ServerLogs();
let button = document.createElement('button');
button.textContent = 'Get Server Logs';
button.onclick = function () {
  serverLogs.getServerLogs();
};

let logResultsDiv = document.createElement('div');
logResultsDiv.setAttribute('id', 'log_results');

document.body.appendChild(button);
document.body.appendChild(logResultsDiv);
