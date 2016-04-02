'use strict';

var gulp = require('gulp');
var purescript = require('gulp-purescript');
var jsValidate = require('gulp-jsvalidate');
var plumber = require("gulp-plumber");
var rimraf = require('rimraf');

var sources = [
  'src/**/*.purs',
  'examples/*/*.purs',
  'bower_components/purescript-*/src/**/*.purs'
];

var foreigns = [
  'src/**/*.js',
  'bower_components/purescript-*/src/**/*.js'
];

gulp.task('jsvalidate', function () {
  return gulp.src(foreigns)
    .pipe(plumber())
    .pipe(jsValidate());
});

gulp.task('clean', function (done) {
  rimraf('output', done);
});

gulp.task('build', function() {
  return purescript.psc({
    src: sources,
    ffi: foreigns
  })
});

gulp.task('docs', function() {
  return purescript.pscDocs({
    src: sources,
    docgen: {
      'Pux.Undo': 'docs/Pux/Undo.md'
    }
  })
})

gulp.task('test', ['build'], function() {
  return purescript.pscBundle({
    output: 'output/bundle.js',
    src: "output/**/*.js"
  });
});

gulp.task('default', ['test']);
