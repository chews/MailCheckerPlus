$(document).ready(function(){
  console.log('did i get called');
  canvas = document.createElement('canvas');
  canvasContext = canvas.getContext('2d');
  gfx = document.createElement('img');
  reloadSettings();
});
