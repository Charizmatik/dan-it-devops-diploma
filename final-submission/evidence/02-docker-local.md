# Local Docker verification
UTC: 2026-09-02T20:12:45.7527393Z
Command: docker build --progress=plain -t dan-it-backend:local .
#0 building with "desktop-linux" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 243B 0.0s done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/python:3.12-slim-bookworm
#2 ...

#3 [auth] library/python:pull token for registry-1.docker.io
#3 DONE 0.0s

#2 [internal] load metadata for docker.io/library/python:3.12-slim-bookworm
#2 DONE 1.7s

#4 [internal] load .dockerignore
#4 transferring context: 153B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 1.45kB done
#5 DONE 0.1s

#6 [1/3] FROM docker.io/library/python:3.12-slim-bookworm@sha256:782412e85d0f0984994c290652577d4018aff08145c85b262bb63dc0c7522254
#6 resolve docker.io/library/python:3.12-slim-bookworm@sha256:782412e85d0f0984994c290652577d4018aff08145c85b262bb63dc0c7522254 0.0s done
#6 sha256:35ef2f664a5c3b1e1408a24bd668ef33b82a89a534709e1c03aac6d50012d51a 249B / 249B 0.1s done
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 0B / 13.67MB 0.3s
#6 sha256:268fd66f673d556a271a784d33c4541102f05dde43657861a8e793eb30ef38dd 0B / 3.53MB 0.2s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 0B / 28.23MB 0.2s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 1.05MB / 13.67MB 0.5s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 3.15MB / 13.67MB 0.6s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 4.19MB / 13.67MB 0.8s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 6.29MB / 13.67MB 0.9s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 7.34MB / 13.67MB 1.1s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 9.44MB / 13.67MB 1.2s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 10.49MB / 13.67MB 1.4s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 11.53MB / 13.67MB 1.5s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 12.58MB / 13.67MB 1.7s
#6 sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 13.67MB / 13.67MB 1.7s done
#6 sha256:268fd66f673d556a271a784d33c4541102f05dde43657861a8e793eb30ef38dd 1.05MB / 3.53MB 2.0s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 2.10MB / 28.23MB 1.8s
#6 sha256:268fd66f673d556a271a784d33c4541102f05dde43657861a8e793eb30ef38dd 2.10MB / 3.53MB 2.1s
#6 sha256:268fd66f673d556a271a784d33c4541102f05dde43657861a8e793eb30ef38dd 3.53MB / 3.53MB 2.3s done
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 5.24MB / 28.23MB 2.6s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 8.39MB / 28.23MB 2.9s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 11.53MB / 28.23MB 3.2s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 13.63MB / 28.23MB 3.3s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 15.73MB / 28.23MB 3.6s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 18.87MB / 28.23MB 3.9s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 20.97MB / 28.23MB 4.2s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 23.07MB / 28.23MB 4.4s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 25.17MB / 28.23MB 4.7s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 27.26MB / 28.23MB 4.8s
#6 sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 28.23MB / 28.23MB 4.9s done
#6 extracting sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71
#6 extracting sha256:a8ac7f6c67abc236e4c745052c404112b8fab6fe8ac3a329d1ef3b867ad67c71 0.8s done
#6 DONE 5.9s

#6 [1/3] FROM docker.io/library/python:3.12-slim-bookworm@sha256:782412e85d0f0984994c290652577d4018aff08145c85b262bb63dc0c7522254
#6 extracting sha256:268fd66f673d556a271a784d33c4541102f05dde43657861a8e793eb30ef38dd 0.1s done
#6 DONE 6.0s

#6 [1/3] FROM docker.io/library/python:3.12-slim-bookworm@sha256:782412e85d0f0984994c290652577d4018aff08145c85b262bb63dc0c7522254
#6 extracting sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e
#6 extracting sha256:ec613f6df89286159c101a9b15264bc627366aaf788a9ea9c3a456ad9b9b2b3e 0.4s done
#6 DONE 6.4s

#6 [1/3] FROM docker.io/library/python:3.12-slim-bookworm@sha256:782412e85d0f0984994c290652577d4018aff08145c85b262bb63dc0c7522254
#6 extracting sha256:35ef2f664a5c3b1e1408a24bd668ef33b82a89a534709e1c03aac6d50012d51a 0.0s done
#6 DONE 6.5s

#7 [2/3] WORKDIR /app
#7 DONE 0.4s

#8 [3/3] COPY backend/app.py ./app.py
#8 DONE 0.1s

#9 exporting to image
#9 exporting layers 0.1s done
#9 exporting manifest sha256:6c5fbc3a900c2947e8d4fe4141bf30000b159c4253b2e2ef6f32521bc7ad596e 0.0s done
#9 exporting config sha256:a53e9059cf1438cf500c6e8cc463576371221d16aad143232be05c98cd1c9364 0.0s done
#9 exporting attestation manifest sha256:2867fd895ee3798dd623152f9ce034201883494dc5020b630191e28ade95f7e0 0.0s done
#9 exporting manifest list sha256:6bb25cc363100e676b700ce09711d575458c74071b149ab057b1204c8a15f23c 0.0s done
#9 naming to docker.io/library/dan-it-backend:local done
#9 unpacking to docker.io/library/dan-it-backend:local 0.0s done
#9 DONE 0.3s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/gddu8gmizj52j39xa9u43pft0
Container: 01c33e4c68b8b672426dd6068a9942b60668ed80e971b5c209f583c33168f968
GET http://127.0.0.1:51284/ -> HTTP 200
Body: {"status": "ok", "ip": "172.17.0.2"}
Container IP verified: 172.17.0.2
Runtime UID: 10001
Server logs:
Server listening on 0.0.0.0:8000
172.17.0.1 - - [02/Sep/2026 20:12:56] "GET / HTTP/1.1" 200 -
Result: PASS. Test container stopped and removed. Image retained locally.
Docker Hub, CI and Kubernetes have not been verified.
