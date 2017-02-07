const del = require('del');
const nib = require('nib');
const gulp = require('gulp');
const path = require('path');
const webpack = require('webpack');
const gutil = require('gulp-util');
const babel = require('gulp-babel');
const watch = require('gulp-watch');
const coffee = require('gulp-coffee');
const filter = require('gulp-filter');
const plumber = require('gulp-plumber');
const sourcemaps = require('gulp-sourcemaps');
const WebpackDevServer = require('webpack-dev-server');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const notifier = require('node-notifier/notifiers/growl')();
const WebpackErrorNotificationPlugin = require('webpack-error-notification');


const PATHS = {
	SRC: './{ui-js,ui-js-loader,server}/**/*',
	DEST: './build/'
};

const PORT = 1337;
const HOST = '0.0.0.0';
const HTML_BUILD = './build/html';

const HTML = './html/index.pug';
const STYLE = './html/index.styl';
const SCRIPT = './html/index.js';

const CONFIG = {

	// devtool: 'source-map',

	entry: ["style!" + STYLE, SCRIPT],

	output: {
		path: path.resolve(HTML_BUILD),
		filename: 'scripts/[hash].js'
	},

	resolve: {
		modulesDirectories: ['build', 'node_modules'],
		extensions: ['', '.js', '.coffee']
	},

	resolveLoader: {
		modulesDirectories: ['build', 'node_modules']
	},

	module: {
		loaders: [
			{test: /\.(html)$/, loader: 'html?minimize=false'},
			{test: /\.(pug)$/, loader: 'pug'},
			{test: /\.(coffee)$/, loader: 'ui-js!coffee'},
			{test: /\.(js)$/, loader: 'babel', query: {presets: ['es2015', 'stage-0']}},
			{test: /\.(css)$/, loader: 'css!autoprefixer?browsers=last 2 version'},
			{test: /\.(styl)$/, loader: 'css!autoprefixer?browsers=last 2 version!stylus'},
			{test: /\.(mp3|mp4|wmv)$/, loader: 'url?limit=10000&name=media/[hash].[ext]'},
			{test: /\.(jpeg|jpg|png|gif|svg)$/, loader: 'url?limit=10000&name=images/[hash].[ext]!img?progressive=true'},
			{test: /\.(eot|otf|svg|ttf|woff)$/, loader: 'url?limit=10000&name=fonts/[hash].[ext]'}
		]
	},

	plugins: [
		new HtmlWebpackPlugin({template: path.resolve(HTML)}),
		new webpack.HotModuleReplacementPlugin(),
		new WebpackErrorNotificationPlugin(webpackNotify)
	],

	node: {
		fs: 'empty'
	},

	stylus: {
		use: [nib()],
		'import': ['~nib/lib/nib/index.styl']
	},

};


function compile(dest, stream) {
	const filterCoffee = filter('**/*.coffee', {restore: true, passthrough: false});
	const filterJs = filter('**/*.js', {restore: true, passthrough: false});

	return stream
		.pipe(plumber({errorHandler: errorHandler}))
		.pipe(filterCoffee)
		.pipe(sourcemaps.init())
		.pipe(coffee())
		.pipe(sourcemaps.write('.'))
		.pipe(filterCoffee.restore)
		.pipe(filterJs)
		.pipe(sourcemaps.init())
		.pipe(babel({presets: ['es2015', 'stage-0']}))
		.pipe(sourcemaps.write('.'))
		.pipe(filterJs.restore)
		.pipe(gulp.dest(dest))
}


function clearBuildDirectory() {
	return del(PATHS.DEST)
}


function clearHTMLBuildDirectory() {
	return del(HTML_BUILD)
}


function watchModules() {
	return compile(PATHS.DEST, watch(PATHS.SRC))
}


function compileModules() {
	return compile(PATHS.DEST, gulp.src(PATHS.SRC))
}


function startWebpackDevServer() {
	CONFIG.entry.unshift('webpack/hot/dev-server')
	CONFIG.entry.unshift("webpack-dev-server/client?http://" + HOST + ":" + PORT)

	return new WebpackDevServer(webpack(CONFIG), {
		stats: 'errors-only',
		hot: true
	}).listen(PORT, HOST)
}


function buildHtml(callback) {
	// CONFIG.devtool = 'source-map'
	// CONFIG.plugins.push(new webpack.optimize.UglifyJsPlugin({
	// 	compress: {warnings: false}
	// }))
	return webpack(CONFIG, callback)
}


function errorHandler(error) {
	notifier.notify({
		title: 'Error',
		message: error.message,
		sound: true,
	})

	gutil.log(
		gutil.colors.cyan('Plumber') + gutil.colors.red('found unhandled error:\n'),
		error.toString()
	)
}


function webpackNotify(message) {
	notifier.notify({
		title: 'Webpack',
		message: message,
		sound: true,
	})

	if (message === 'Successful build') {
		gutil.log('Webpack', message)
	}
	else {
		gutil.log('Webpack', gutil.colors.red(message))
	}
}


gulp.task('production', gulp.series(clearHTMLBuildDirectory, compileModules, buildHtml))
gulp.task('dev', gulp.parallel(watchModules, startWebpackDevServer))
gulp.task('default', gulp.parallel('dev'))

