` a primitive HTTP static file server
	written in Ink, from github.com/thesephist/ink/blob/master/samples/fileserver.ink`

DIR := './public'
PORT := 7800

` short non-comprehensive list of MIME types `
TYPES := {
	` text formats `
	html: 'text/html'
	js: 'text/javascript'
	css: 'text/css'
	txt: 'text/plain'
	md: 'text/plain'
	` serve ink source code as plain text`
	ink: 'text/plain'

	` image formats `
	jpg: 'image/jpeg'
	jpeg: 'image/jpeg'
	png: 'image/png'
	gif: 'image/gif'
	svg: 'image/svg+xml'

	` other misc `
	pdf: 'application/pdf'
	zip: 'application/zip'
}

std := load('std')

log := std.log
encode := std.encode
readRawFile := std.readRawFile

close := listen('0.0.0.0:' + string(PORT), evt => (
	evt.type :: {
		'error' -> log('Server error: ' + evt.message)
		'req' -> (
			` normalize path `
			path := DIR + evt.data.url
			path := (path.(len(path) - 1) :: {
				'/' -> path + 'index.html'
				_ -> path
			})
			reqStart := time()

			log(evt.data.method + ': ' + evt.data.url)
		
			` pre-define callback to readRawFile `
			readHandler := (path, fileBody, withIndex) => (
				` there seems to be a funny bug on macOS where sometimes a read
					of a directory as a file will succeed and return no bytes `
				fileBody := (fileBody :: {
					{} -> ()
					_ -> fileBody
				})

				[fileBody, withIndex] :: {
					` if not found, maybe try again with /index.html appended? `
					[(), false] -> (
						log('-> ' + path + ' not found, trying with /index.html')
						readRawFile(path + '/index.html', data => readHandler(path + '/index.html', data, true))
					)
					` if this is the second attempt, just give up `
					[(), true] -> (
						log('-> ' + path + ' not found')
						(evt.end)({
							status: 404
							headers: {
								'Content-Type': 'text/plain'
								'X-Served-By': 'ink-serve'
							}
							body: encode('not found')
						})
					)
					` if found on an /index.html suffix, redirect `
					[_, true] -> (
						elapsedMs := (time() - reqStart) * 1000
						log('-> ' + evt.data.url + ' type: ' + getType(path) + ' redirected in ' + string(floor(elapsedMs)) + 'ms')
						(evt.end)({
							status: 301
							headers: {
								'Content-Type': 'text/plain'
								'X-Served-By': 'ink-serve'
								'Location': evt.data.url + '/'
							}
							body: []
						})
					)
					_ -> (
						elapsedMs := (time() - reqStart) * 1000
						log('-> ' + evt.data.url + ' type: ' + getType(path) + ' served in ' + string(floor(elapsedMs)) + 'ms')
						(evt.end)({
							status: 200
							headers: {
								'Content-Type': getType(path)
								'X-Served-By': 'ink-serve'
							}
							body: fileBody
						})
					)
				}
			)

			evt.data.method :: {
				'GET' -> readRawFile(path, data => readHandler(path, data, false))
				_ -> (
					` if other methods, just drop the request `
					log('-> ' + evt.data.url + ' dropped')
					(evt.end)({
						status: 405
						headers: {
							'Content-Type': 'text/plain'
							'X-Served-By': 'ink-serve'
						}
						body: encode('method not allowed')
					})
				)
			}
		)
	}
))

` given a path, get the MIME type `
getType := path => (
	guess := TYPES.(getPathEnding(path))
	guess :: {
		() -> 'application/octet-stream'
		_ -> guess
	}
)

` given a path, get the file extension `
getPathEnding := path => (
	(sub := (idx, acc) => idx :: {
		0 -> path
		_ -> path.(idx) :: {
			'.' -> acc
			_ -> sub(idx - 1, path.(idx) + acc)
		}
	})(len(path) - 1, '')
)
