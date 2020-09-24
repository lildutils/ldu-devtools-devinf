const packageJson = require('./package.json');
const buildUtils = require('@ldu-devtools/gulputils').buildUtils;
const gulp = require('gulp');
const concat = require('gulp-concat');
const insert = require('gulp-insert');
const del = require('del');
const exec = require('child_process').exec;
const merge = require('merge-stream');

const gulpConfigs = {
    base: 'src/main',
    build: 'build',
    dist: 'dist',
    tmp: 'tmp',
    zip: 'build',
    lib: 'lib',
    projectCore: '_core',
    projectType: buildUtils.processArgs().projectType,
    projectTypesAvailable: [
        'gulp'
    ],
    watching: {
        events: 'all',
        delay: 500
    },
    others: [
        'README.md',
        'LICENSE'
    ]
};

if (gulpConfigs.projectType === undefined
    || gulpConfigs.projectType === null
    || gulpConfigs.projectType.length === 0) {
    throw new Error('ERR: "projectType" is required');
}

if (gulpConfigs.projectTypesAvailable.indexOf(gulpConfigs.projectType) === -1) {
    throw new Error('ERR: "projectType" => ' + gulpConfigs.projectType + ' is not supperted');
}

function cleanDist() {
    return del([gulpConfigs.dist + '/**/*']);
}
cleanDist.displayName = 'clean:dist';
gulp.task('clean', cleanDist);

function copyFiles() {
    return merge(
        copySource(),
        copyConfigsJson(),
        copyPackageJson(),
        copyOthers()
    );
}
copyFiles.displayName = 'copy:files';
gulp.task('copy', copyFiles);

function copySource() {
    return merge(
        copySourceBat(),
        copySourceSh()
    );
}
copySource.displayName = 'copy:src';
gulp.task('copySource', copySource);

function copySourceBat() {
    return gulp.src([
        gulpConfigs.base + '/bat/' + gulpConfigs.projectCore + '/**/*.bat',
        gulpConfigs.base + '/bat/' + gulpConfigs.projectType + '/**/*.bat'
    ]).pipe(gulp.dest(gulpConfigs.dist + '/'));
}
copySourceBat.displayName = 'copy:src-bat';
gulp.task('copySourceBat', copySourceBat);

function copySourceSh() {
    return gulp.src([
        gulpConfigs.base + '/sh/' + gulpConfigs.projectCore + '/**/*.sh',
        gulpConfigs.base + '/sh/' + gulpConfigs.projectType + '/**/*.sh'
    ]).pipe(gulp.dest(gulpConfigs.dist + '/'));
}
copySourceSh.displayName = 'copy:src-sh';
gulp.task('copySourceSh', copySourceSh);

function copyConfigsJson() {
    return gulp.src([gulpConfigs.base + '/resources/configs-' + gulpConfigs.projectType + '.json'])
        .pipe(concat('configs.json'))
        .pipe(gulp.dest(gulpConfigs.dist + '/'));
}
copyConfigsJson.displayName = 'copy:conf';
gulp.task('copyConfigsJson', copyConfigsJson);

function copyPackageJson() {
    return gulp.src(['package.json'])
        .pipe(insert.transform(function () {
            return '{"name":"' + packageJson.name + '","version":"' + packageJson.version + '","projectType":"' + gulpConfigs.projectType + '"}';
        }))
        .pipe(gulp.dest(gulpConfigs.dist + '/'));
}
copyPackageJson.displayName = 'copy:package-json';
gulp.task('copyPackageJson', copyPackageJson);

function copyOthers() {
    return gulp.src(gulpConfigs.others)
        .pipe(gulp.dest(gulpConfigs.dist + '/'));
}
copyOthers.displayName = 'copy:others';
gulp.task('copyOthers', copyOthers);

function createZip(cb) {
    exec('cd ' + gulpConfigs.dist + ' && npm pack', function (result) {
        cb(result);
    });
};
createZip.displayName = 'create:zip';
gulp.task('createZip', createZip);

function copyZip() {
    return gulp.src([gulpConfigs.dist + '/*.tgz'])
        .pipe(gulp.dest(gulpConfigs.build + '/' + gulpConfigs.projectType + '/'));
}
copyZip.displayName = 'copy:zip';
gulp.task('copyZip', copyZip);

function cleanZip() {
    return del([gulpConfigs.dist + '/*.tgz']);
}
cleanZip.displayName = 'clean:zip';
gulp.task('cleanZip', cleanZip);

const buildProject = gulp.series(
    cleanDist,
    copyFiles,
    createZip,
    copyZip,
    cleanZip
);
gulp.task('build', buildProject);

gulp.task('default', buildProject);
