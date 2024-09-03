import * as d3 from 'd3';
import * as sszvis from 'sszvis';
import 'shiny';
import { makeBarChart } from './modules/makeBarChart.js';

// hacky way of adding the sszvis stylesheet (should also be possible based on the package?)
$('head').append('<link rel="stylesheet" type="text/css" href="https://unpkg.com/sszvis@3/build/sszvis.css">');

makeBarChart(d3, sszvis);

