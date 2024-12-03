"""
Add Exporter User
"""

from yoyo import step

__depends__ = {}

steps = [
    step(
        """
        CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'password' WITH MAX_USER_CONNECTIONS 3;
        CREATE USER 'exporter'@'mysql' IDENTIFIED BY 'password' WITH MAX_USER_CONNECTIONS 3;
        GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
        GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'mysql';
        """,
        """
        DROP USER 'exporter'@'localhost';
        DROP USER 'exporter'@'mysql';
        """
    )
]
