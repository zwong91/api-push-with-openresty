import os
from flask import Flask

server = Flask(__name__)

@server.route('/')
def listABC():

    return '<div> backend-service-zhihu ' + '</div>'

if __name__ == '__main__':
    server.run()
