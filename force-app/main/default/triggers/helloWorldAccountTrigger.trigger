trigger helloWorldAccountTrigger on Account (before insert) {
    MyHelloWorld.addHelloWorld(Trigger.New);
}