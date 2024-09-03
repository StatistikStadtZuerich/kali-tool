import * as d3 from 'd3';
import * as sszvis from 'sszvis';
import 'shiny';
import { message } from './modules/message.js';
import { makeBarChart } from './modules/makeBarChart.js';


// In shiny server use:
// session$sendCustomMessage('show-packer', 'hello packer!')
Shiny.addCustomMessageHandler('show-packer', (msg) => {
  message(msg);
})

makeBarChart(d3, sszvis);

