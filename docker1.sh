# ---------------------------------------------------------------------------
# Docker Configuration Discovery (Host + Containers)
# ---------------------------------------------------------------------------

dash_sep() { echo "-----------------------------------------------------------------------"; }
sep() { echo "======================================================================="; }
empty_line() { echo ""; }

echo "Docker-related configuration files (host and containers):"
dash_sep

# --- 1. Host Configuration Files ---
echo "Host configuration files:"
dash_sep

search_paths="."
if [ -d "/opt" ]; then
    search_paths="$search_paths /opt"
fi
if [ -d "/srv" ]; then
    search_paths="$search_paths /srv"
fi
if [ -d "/var/lib/docker" ]; then
    search_paths="$search_paths /var/lib/docker"
fi

# Find docker-related configs
find $search_paths -type f \( \
    -name "docker-compose*.yml" -o \
    -name "compose.yml" -o \
    -name "Dockerfile" -o \
    -name ".env" -o \
    -name "*.env" -o \
    -name "docker-compose*.yaml" \
    \) 2>/dev/null | sed 's/^/Host: /'

empty_line
dash_sep
echo "Inspecting containers for configuration files:"
dash_sep

# --- 2. Inside Containers ---
if command -v docker >/dev/null 2>&1; then
    containers=$(docker ps -q)
    if [ -z "$containers" ]; then
        echo "No running containers found."
    else
        for cid in $containers; do
            cname=$(docker inspect --format '{{.Name}}' "$cid" 2>/dev/null | sed 's#^/##')
            echo "Container: $cname"
            docker exec "$cid" sh -c '
                find / -type f \( \
                    -name ".env" -o \
                    -name "*.env" -o \
                    -name "docker-compose.yml" -o \
                    -name "docker-compose.yaml" -o \
                    -name "compose.yml" -o \
                    -name "Dockerfile" -o \
                    -name "config.json" -o \
                    -name "application.yml" -o \
                    -name "settings.py" -o \
                    -name "appsettings.json" -o \
                    -name "config.js" -o \
                    -name "*.conf" \
                \) 2>/dev/null | head -n 20
            ' 2>/dev/null | sed 's/^/    /'
            echo ""
        done
    fi
else
    echo "Docker command not found."
fi

sep
empty_line
