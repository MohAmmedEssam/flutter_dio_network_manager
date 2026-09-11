## 0.0.3

* Fix: `NetworkExecuter` no longer crashes when a non-JSON error body (String/List/null) is returned by the server; error message extraction is now null/type safe.
* Fix: `isLoading` callback in `NetworkExecuter.download` reported the inverse of the actual download state; it now correctly reports `true` while in progress and `false` once complete.
* Fix: native (non-web) downloads now honor `sendTimeout`/`receiveTimeOut` from `BaseClientGenerator`, matching the web download path.
* Fix: `_getSavePath` no longer throws on Android/iOS, where `path_provider`'s `getDownloadsDirectory()` throws `UnsupportedError` instead of returning `null`; it now falls back to the application documents directory as intended.
* Fix: `UploadFile.key` set to `null` no longer crashes `setMultipart`/`setMultipartFiles`; it falls back to the default `'file'` key.
* Enhancement: request/response logging (`PrettyDioLogger`) is now enabled only in debug builds, preventing sensitive headers/bodies from being logged in production.
* Enhancement: `NetworkCreator.request` no longer mutates the caller's `body`/`query` maps in place when stripping null values; it now operates on copies.

## 0.0.1

* TODO: Describe initial release.
