import os
from flask import Flask

server = Flask(__name__)
conn = None

@server.route('/')
def listBlog():
    return '<div> backend-service-madou ' + '</div>'

if __name__ == '__main__':
    server.run()
