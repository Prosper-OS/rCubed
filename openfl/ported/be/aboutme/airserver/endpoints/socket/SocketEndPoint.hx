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
    private var port : Int;
    private var portLimit : Int;
    private var socketClientHandlerFactory : SocketClientHandlerFactory;
    private var serverSocket : ServerSocket;
    
    private var clientHandlers : Array<SocketClientHandler>;
    
    public function new(port : Int, socketClientHandlerFactory : SocketClientHandlerFactory)
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
        
        while (this.port < this.portLimit)
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
        
        for (clientHandler in clientHandlers)
        {
            clientHandler.close();
        }
        
        //reset vector
        clientHandlers = new Array<SocketClientHandler>();
        
        //close the socket
        if (serverSocket != null && serverSocket.bound)
        {
            serverSocket.close();
        }
    }
    
    private function clientConnectHandler(event : ServerSocketConnectEvent) : Void
    //create the clienthandler
    {
        
        var clientHandler : IClientHandler = socketClientHandlerFactory.createHandler(event.socket);
        
        //add event listeners to the clienthandler
        clientHandler.addEventListener(Event.CLOSE, clientHandlerCloseHandler, false, 0, true);
        clientHandlers.push(clientHandler);
        
        //dispatch added event
        var e : EndPointEvent = new EndPointEvent(EndPointEvent.CLIENT_HANDLER_ADDED);
        e.clientHandler = clientHandler;
        dispatchEvent(e);
    }
    
    private function serverSocketCloseHandler(event : Event) : Void
    {
        close();
    }
    
    private function clientHandlerCloseHandler(event : Event) : Void
    {
        var clientHandler : IClientHandler = try cast(event.target, IClientHandler) catch(e:Dynamic) null;
        
        //remove event listener
        clientHandler.removeEventListener(Event.CLOSE, clientHandlerCloseHandler);
        
        //remove it from the vector
        var i : Int = as3hx.Compat.parseInt(clientHandlers.length - 1);
        while (i >= 0)
        {
            if (clientHandlers[i] == clientHandler)
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

