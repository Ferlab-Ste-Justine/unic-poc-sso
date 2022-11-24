FROM bash

COPY set-spark-config.sh .

ENTRYPOINT ["./set-spark-config.sh"]
CMD ["/etc/input", "/etc/output"]