import * as d3 from 'd3';
import * as sszvis from 'sszvis';
import 'shiny';
import { makeBarChart } from './modules/makeBarChart.js';

// import scss, which is where the css from the sszvis package is included
import "../scss/main.scss";

makeBarChart(d3, sszvis);

