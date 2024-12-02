load("github.com/ocuroot/sdk/v0/package.star", "package")
load("github.com/ocuroot/sdk/v0/sleep.star", "sleep")

def build():
    print("building...")
    for i in range(0, 100):
        print("Tick {}".format(i))   
        sleep(1000)

def deploy():
    print("deploying...")
    for i in range(0, 60):
        print("Tick {}".format(i))   
        sleep(1000)

package(
  name="long",
  build=build,
  deploy=deploy,
)