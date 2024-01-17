export type TParamValue = any
export type TParams = Record<string, TParamValue>

export type TTaskParams<T extends TParams=TParams> = T & {
  env: string
}

export type TTaskOptionType = 'string'
  | 'str'
  | 'number'
  | 'num'
  | 'boolean'
  | 'bool'
  | 'array'
  | 'arr'
  | 'object'
  | 'obj'

export type TTaskOption = {
  env?: string
  alias?: string[]
  allowed?:string[]
  example?: string
  required?:boolean
  description?: string
  default?: TParamValue
  type?: TTaskOptionType
}

export type TTaskOptions = Record<string, TTaskOption>

export type TTaskActionArgs<T extends TParams=TParams> = {
  task: TTask
  tasks: TTasks
  options?: string[]
  params: TTaskParams<T>
  config?: Record<string, any>
}

export type TTaskAction<P extends TParams=TParams> = <T extends P=P>(args:TTaskActionArgs<T>) => any

export type TTask<T extends TParams=TParams> = {
  name: string,
  alias?: string[]
  action?: TTaskAction<T>
  tasks?: TTasks
  options?: TTaskOptions
  [key: string]: any
}

export type TTasks = Record<string, TTask>
