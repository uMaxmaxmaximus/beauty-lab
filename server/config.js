import path from 'path'


export default {
	port: 8081,
	storage: path.resolve(__dirname, '../html/storage'),

	dbName: 'beauty-lab',
	dbUser: 'root',
	dbPass: '',

	emailFrom: 'Иванов Иван 👥" <imaxmaxmaximus@gmail.com>',
	emailLogin: 'imaxmaxmaximus',
	emailPass: 'Livanderiamarum2105',

	timezoneOffset: -240, // set timezone UTC +4 (Ульяновск)
}

