ARG PSVersionMajor=7
ARG PSVersionMinor=4
ARG PSVersionPatch=2
ARG PSVersion="${PSVersionMajor}.${PSVersionMinor}.${PSVersionPatch}"
ARG PSVersionMajor="${PSVersion/.*}"

FROM alpine:latest AS Downloader

ARG PSVersion
ARG PSVersionMajor

RUN apk update && apk add --no-cache curl \
    && curl -fOL "https://github.com/PowerShell/PowerShell/releases/download/v${PSVersion}/powershell-${PSVersion}-linux-musl-x64.tar.gz" \
    && mkdir -p "/opt/powershell/${PSVersionMajor}" \
    && tar -xf "powershell-${PSVersion}-linux-musl-x64.tar.gz" -C "/opt/powershell/${PSVersionMajor}" \
    && chmod a+x "/opt/powershell/${PSVersionMajor}/pwsh"

FROM alpine:latest AS Main

ARG PSVersionMajor

RUN apk update && apk add --no-cache \
    ca-certificates-bundle libgcc libssl3 libstdc++ zlib libgdiplus icu-libs ncurses-terminfo-base

COPY --from=Downloader /opt/powershell /opt/powershell

RUN ln -s "/opt/powershell/${PSVersionMajor}/pwsh" /usr/bin/pwsh \
    && ln -s "/opt/powershell/${PSVersionMajor}/pwsh" /usr/bin/PowerShell

ENTRYPOINT [ "pwsh" ]