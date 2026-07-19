package be.aboutme.airserver;

import be.aboutme.airserver.endpoints.IEndPoint;
import be.aboutme.airserver.events.AIRServerEvent;
import be.aboutme.airserver.events.EndPointEvent;
import be.aboutme.airserver.events.MessageReceivedEvent;
import be.aboutme.airserver.messages.Message;
import openfl.events.Event;
import openfl.events.EventDispatcher;

@:meta(Event(name="clientAdded",type="be.aboutme.airserver.events.AIRServerEvent"))

@:meta(Event(name="clientRemoved",type="be.aboutme.airserver.events.AIRServerEvent"))

@:meta(Event(name="messageReceived",type="be.aboutme.airserver.events.MessageReceivedEvent"))

/**
 * The AIRServer class provides an easy way to create a server application in Adobe AIR.
 *
 * <p>Simply create an instance of this class, add endpoints & start the server. Events are
 * triggered when users connect, send messages and disconnect from the server</p>
 *
 * <p><code>var airServer:AIRServer = new AIRServer();</code></p>
 * <p><code>airServer.addEndPoint(new SocketEndPoint(1234, new AMFSocketClientHandlerFactory()));</code></p>
 * <p><code>airServer.addEndPoint(new SocketEndPoint(1235, new WebSocketClientHandlerFactory()));</code></p>
 * <p><code>airServer.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler);</code></p>
 * <p><code>airServer.addEventListener(AIRServerEvent.CLIENT_ADDED, clientAddedHandler);</code></p>
 * <p><code>airServer.addEventListener(AIRServerEvent.CLIENT_REMOVED, clientRemovedHandler);</code></p>
 * <p><code>airServer.start();</code></p>
 */
class AIRServer extends EventDispatcher
{
    public var clients(get, never) : Array<Client>;

    private static var GUID_CLIENT : Int = 0;
    
    private var started : Bool;
    
    private var endPoints : Array<IEndPoint>;
    private var _clients : Array<Client>;
    
    private function get_clients() : Array<Client>
    {
        return _clients.copy();
    }
    
    private var clientsMap : Dynamic;
    
    public function new()
    {
        super();
        _clients = new Array<Client>();
        endPoints = new Array<IEndPoint>();
        clientsMap = { };
    }
    
    /**
     * Adds an endpoint to the server. An endpoint provides a way to connect
     * to the server.
     *
     * <p><code>airServer.addEndPoint(new SocketEndPoint(1234, new AMFSocketClientHandlerFactory())
     * );</code></p>
     */
    public function addEndPoint(endPointToAdd : IEndPoint) : Void
    {
        if (Lambda.indexOf(endPoints, endPointToAdd) == -1)
        {
            endPoints.push(endPointToAdd);
        }
    }
    
    /**
     * Starts the server: this will start all added endpoints and listen for
     * connections / data on those endpoints.
     */
    public function start() : Bool
    {
        var startedEndpoints : Int = 0;
        
        //open all endpoints
        for (endPoint in endPoints) {
endPoint.addEventListener(EndPointEvent.CLIENT_HANDLER_ADDED, clientHandlerAddedHandler, false, 0, true);
            
            //open it
            if (endPoint.open())
            {
                startedEndpoints++;
            }
        }
        started = true;
        
        return startedEndpoints == endPoints.length;
    }
    
    /**
     * Stops the server: this will stop all endpoints, meaning all the
     * connected clients will be disconnected from the server.
     */
    public function stop() : Void
    //close all endpoints
    {
        
        for (endPoint in endPoints) {
endPoint.close();
            
            //remove event listeners from the endpoint
            endPoint.removeEventListener(EndPointEvent.CLIENT_HANDLER_ADDED, clientHandlerAddedHandler);
        }
        started = false;
    }
    
    /**
     * Send a message to all the connected clients.
     */
    public function sendMessageToAllClients(message : Message) : Void
    {
        for (client in _clients)
        {
            client.sendMessage(message);
        }
    }
    
    private function clientHandlerAddedHandler(event : EndPointEvent) : Void
    {
        var client : Client = new Client(GUID_CLIENT++, event.clientHandler);
        _clients.push(client);
        Reflect.setField(clientsMap, Std.string(client.id), client);
        
        //add events to client
        client.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler, false, 0, true);
        client.addEventListener(Event.CLOSE, clientCloseHandler, false, 0, true);
        
        //dispatch added event
        var e : AIRServerEvent = new AIRServerEvent(AIRServerEvent.CLIENT_ADDED);
        e.client = client;
        dispatchEvent(e);
    }
    
    private function clientCloseHandler(event : Event) : Void
    {
        var client : Client = try cast(event.target, Client) catch(e:Dynamic) null;
        var index : Int = Lambda.indexOf(_clients, client);
        if (index > -1)
        {
            _clients.splice(index, 1);
        }
        Reflect.deleteField(clientsMap, client.id); //remove event listeners  ;
        
        
        
        client.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler);
        client.removeEventListener(Event.CLOSE, clientCloseHandler);
        
        //dispatch removed event
        var e : AIRServerEvent = new AIRServerEvent(AIRServerEvent.CLIENT_REMOVED);
        e.client = client;
        dispatchEvent(e);
    }
    
    /**
     * Get a client, specified by it's client id
     */
    public function getClientById(clientId : Int) : Client
    {
        return Reflect.field(clientsMap, Std.string(clientId));
    }
    
    /**
     * Get the port number of open endpoint for the given type.
     * @param type Type of endpoint
     * @return port number
     */
    public function getPortNumber(type : String) : Int
    {
        for (endPoint in endPoints)
        {
            if (endPoint.type() == type)
            {
                return endPoint.currentPort();
            }
        }
        
        return 0;
    }
    
    private function messageReceivedHandler(event : MessageReceivedEvent) : Void
    {
        dispatchEvent(event.clone());
    }
}

