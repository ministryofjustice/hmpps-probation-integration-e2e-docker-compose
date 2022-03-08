FROM oraclelinux:8

# Install SQL client
RUN dnf install -y oracle-instantclient-release-el8 && \
    dnf install -y oracle-instantclient-sqlplus

# Install AWS CLI
RUN dnf install -y unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

COPY tests /tests