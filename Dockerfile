# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension auchenberg.vscode-browser-preview
RUN code-server --install-extension dracula-theme.theme-dracula
RUN code-server --install-extension vscode-icons-team.vscode-icons


# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make
RUN sudo apt install -y wget
RUN sudo apt install -y git
RUN sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN sudo apt install -y nodejs
RUN sudo apt install -y build-essential
RUN sudo npm install -g yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN sudo apt-get install chromium -y
RUN sudo apt-get install -y python3-pip

# SDK: Dotnet Core
RUN wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    sudo apt-get update && \
    # sudo apt install -y dotnet-sdk-6.0 dotnet-runtime-6.0 && \
    sudo apt install -y dotnet-sdk-5.0 dotnet-runtime-5.0 && \
    dotnet tool install -g dotnet-ef && \
    dotnet new --install Amazon.Lambda.Templates::5.0.0 && \
    dotnet tool install -g Amazon.Lambda.Tools && \
    dotnet tool install -g JetBrains.ReSharper.GlobalTools && \
    chown -R $DEFAULT_USER:$DEFAULT_USER /tmp/NuGetScratch

# SDK: AWS CLI, aws-shell
RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    pip3 install aws-shell --user

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=4501
EXPOSE 4501-8000

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
