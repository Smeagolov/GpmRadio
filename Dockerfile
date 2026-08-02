FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="RadioPlayer" \
      org.opencontainers.image.description="Player de rádio HTML5 com now playing, capa do álbum, letra e PWA" \
      org.opencontainers.image.source="https://github.com/jailsonsb2/RadioPlayer" \
      org.opencontainers.image.licenses="AGPL-3.0-or-later"

# Configuração padrão: sem nenhuma variável de ambiente o container sobe
# funcionando, tocando a rádio da demo.
ENV RADIO_NAME="Jailson Web Rádio" \
    URL_STREAMING="https://stream.zeno.fm/yn65fsaurfhvv" \
    API_URL="" \
    FALLBACK_API_URL="" \
    ACCENT_COLOR="" \
    BG_COLOR="" \
    THEME_COLOR="#0b0e13"

COPY css/ /usr/share/nginx/html/css/
COPY fonts/ /usr/share/nginx/html/fonts/
COPY img/ /usr/share/nginx/html/img/
COPY js/ /usr/share/nginx/html/js/
COPY index.html service-worker.js llms.txt /usr/share/nginx/html/

# A AGPL-3.0 acompanha o binário: quem redistribui ou hospeda esta imagem
# precisa dela junto.
COPY LICENSE /usr/share/nginx/html/LICENSE

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# A imagem oficial do nginx executa tudo em /docker-entrypoint.d/ antes de
# subir o servidor — é onde geramos config.js e manifest.json.
COPY docker/40-radioplayer-config.sh /docker-entrypoint.d/40-radioplayer-config.sh
RUN chmod +x /docker-entrypoint.d/40-radioplayer-config.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/index.html || exit 1
