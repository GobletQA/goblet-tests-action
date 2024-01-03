
const runImg = async () => {
  
}

export const run = {
  name: `run`,
  action: runImg,
  alias: [`rn`, `rnu`],
  options: {
    context: {
      example: `--context proxy`,
      alias: [`ctx`, `name`, `type`],
      description: `Context or name to use when resolving the Dockerfile to built`,
    },
    cmd: {
      alias: [`command`, `cdm`, `cd`],
      example: `--cmd "ls -ls /goblet/app"`,
      description: `Override the default command of the docker image`,
    },
    ports: {
      default: [],
      type: `array`,
      alias: [`pt`, `port`],
      description: `Bind a local port to the docker containers port`,
    },
    attach: {
      default: true,
      type: `boolean`,
      alias: [`it`, `att`],
      description:
        `Attach to the stdio of the running container, same as -it option of the docker cli`,
    },
    remove: {
      default: true,
      alias: [`rm`],
      type: `boolean`,
      description:
        `Automatically remove the container once it is stopped, same as --rm option of the docker cli`,
    },
    pull: {
      alias: [`pl`],
      example: `--pull`,
      default: `never`,
      description: `Image pull policy passed to the docker cli`,
    },
    name: {
      alias: [`nm`],
      example: `--name my-container`,
      description: `Name of the container being run`,
    },
    volumes: {
      type: `array`,
      alias: [`vol`, `vols`],
      example: `--volumes /local/1/path:/remote/1/path,/local/2/path:/remote/2/path`,
      description: `Volumes to mount to the running container separated by a comma`,
    },
    vnm: {
      type: `bool`,
      default: false,
      alias: [`volume-node-modules`, `vol-node-modules`, `v-nm`, `vol-nm`],
      description: `Include node_module paths in custom defined volumes`
    },
    mount: {
      alias: [`mt`],
      type: `boolean`,
      example: `--mount `,
      description: `Auto mounts the root directory into the container`,
    },
    image: {
      alias: [`img`, `igm`, `im`],
      example: `--image backend`,
      description: `Name of the image to be run, can also include the tag separated by a :`,
    },
    tag: {
      alias: [`tg`, `tga`],
      default: `values`,
      example: `--tag package`,
      description: `Name of the tag of the image to be run if separate from the defined image`,
    },
    privileged: {
      type: `boolean`,
      alias: [`priv`, `prv`],
      example: `--privileged`,
      description: `Run the docker images with the --privileged option`,
    },
    envs: {
      type: `array`,
      example: `--envs key1:value1,key2:value2`,
      description: `Custom envs to pass to the image. Override the default from values file`,
    },
    log: {
      type: `boolean`,
      description: `Log command before they are build`,
    },
    fallback: {
      alias: [`fb`],
      default: true,
      type: `boolean`,
      description: `Use Values file ENVs as fallback when loading envs`,
    }
  },
}
