# docker file for ciborg tools
# escape=`


# ====================================
# build production image (final stage)
# ====================================
# base image
FROM alpine
MAINTAINER Fidy Andrianaivo (fidy@andrianaivo.org)
LABEL Description="ciborg base image"

# -- set APP environments
# APP name
ARG APP_NAME="ciborg"
ENV APP_NAME ${APP_NAME}
# APP base path
ARG APP_PATH="/project"
ENV APP_PATH ${APP_PATH}

# -- set SYS environments
# prompt
ENV PS1='[ciborg] \h:\w\$ '

# timezone
ARG TZ="Europe/Vienna"
ENV TZ ${TZ}

# copy temporary build files
COPY . /tmp/
WORKDIR /tmp

# setup application dependencies
RUN apk add --no-cache $(grep -vE "^(#.*|$)" requirements.pkg) \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone \
  && pip3 install --upgrade  --no-cache-dir pip \
  && pip install --upgrade -r requirements.pip \
  && export TARGET_DIR=/usr/local/bin \
  && ansible-playbook -e "APP_PATH=${APP_PATH}" requirements.yaml \
  && for external_tool in $(grep -vE "^(#.*|$)" requirements.tools); do bash tools.download.${external_tool};echo;sleep 2;done

# adding test files
COPY tests /tests/

# switch to application dir
WORKDIR ${APP_PATH}

# define application dir as volume
VOLUME ${APP_PATH}

# use wrapper script as entrypoint
ENTRYPOINT ["run.sh"]


# eof
