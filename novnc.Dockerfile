FROM scratch
COPY --from=novnc / /novnc
COPY --from=websockify / /websockify
