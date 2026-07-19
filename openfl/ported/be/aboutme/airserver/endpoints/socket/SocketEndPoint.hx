package be.aboutme.airserver.endpoints.socket;

import openfl.errors.Error;
import be.aboutme.airserver.endpoints.IClientHandler;
import be.aboutme.airserver.endpoints.IEndPoint;
import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
import be.aboutme.airserver.events.EndPointEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.ServerSocketConnectEvent;
import openfl.net.ServerSocket;

class SocketEndPoint extends EventDispatcher implements IEndPoint
{
    private var port                              : Dynamic;
    private var portLimit                              : Dynamic;
    private var socketClientHandlerFactory                              : Dynamic;
    private var serverSocket                              : Dynamic;
    
    private var clientHandlers                              : Dynamic;
    
    public function new(port                              : Dynamic, socketClientHandlerFactory                              : Dynamic)
    {
        super();
        this.port = port;
        this.portLimit = Math.min(port + 10, 0xFFFF);
        this.socketClientHandlerFactory = socketClientHandlerFactory;
        clientHandlers = new Array<SocketClientHandler>();
    }
    
    public function open() : Bool
    {
        clientHandlers = new Array<SocketClientHandler>();
        
        while (as3hx.Compat.truthy(this.port < this.portLimit))
        {
            try {
serverSocket = new ServerSocket();
                serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, clientConnectHandler, false, 0, true);
                serverSocket.addEventListener(Event.CLOSE, serverSocketCloseHandler, false, 0, true);
                serverSocket.bind(port);
                serverSocket.listen();
                break;
            }
            catch (error : Error)
            {
            }
            this.port++;
        }
        
        return true;
    }
    
    public function close() : Void
    //close all socket clienthandlers
    {
        
        for (clientHandler in as3hx.Compat.iter(clientHandlers))
        {
            clientHandler.close();
        }
        
        //reset vector
        clientHandlers = new Array<SocketClientHandler>();
        
        //close the socket
        if (as3hx.Compat.truthy(serverSocket != null && serverSocket.bound))
        {
            serverSocket.close();
        }
    }
    
    private function clientConnectHandler(event                              : Dynamic) : Void
    //create the clienthandler
    {
        
        var clientHandler                              : Dynamic= socketClientHandlerFactory.createHandler(event.socket);
        
        //add event listeners to the clienthandler
        clientHandler.addEventListener(Event.CLOSE, clientHandlerCloseHandler, false, 0, true);
        clientHandlers.push(clientHandler);
        
        //dispatch added event
        var e                              : Dynamic= new EndPointEvent(EndPointEvent.CLIENT_HANDLER_ADDED);
        e.clientHandler = clientHandler;
        dispatchEvent(e);
    }
    
    private function serverSocketCloseHandler(event                              : Dynamic) : Void
    {
        close();
    }
    
    private function clientHandlerCloseHandler(event                              : Dynamic) : Void
    {
        var clientHandler                              : Dynamic= try cast(event.target, IClientHandler) catch(e:Dynamic) null;
        
        //remove event listener
        clientHandler.removeEventListener(Event.CLOSE, clientHandlerCloseHandler);
        
        //remove it from the vector
        var i                              : Dynamic= as3hx.Compat.parseInt(clientHandlers.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            if (as3hx.Compat.truthy(clientHandlers[i] == clientHandler))
            {
                clientHandlers.splice(i, 1);
            }
            i--;
        }
    }
    
    public function type() : String
    {
        return socketClientHandlerFactory.type;
    }
    
    public function currentPort() : Int
    {
        return (serverSocket != null && serverSocket.bound) ? serverSocket.localPort : 0;
    }
}

