FROM ubuntu:24.04

RUN apt update && apt install -y stress-ng sysstat time

# bin/DeadlineTest をコンテナに入れる
COPY bin/DeadlineTest /usr/local/bin/DeadlineTest

# log/ ディレクトリを作っておく（中身はホストと共有でも良い）
RUN mkdir -p /workspace/log

# run時のワーキングディレクトリ
WORKDIR /workspace

# デフォルトのコマンド（あとで run_container.sh で上書きできる）
ENTRYPOINT ["/usr/local/bin/DeadlineTest"]
