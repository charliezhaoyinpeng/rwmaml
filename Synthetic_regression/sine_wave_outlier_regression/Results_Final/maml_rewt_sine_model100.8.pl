��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2171089653328qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2171089652656qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2171089655440qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2171089650736q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2171089651312q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2171089655536q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2171089650736qX   2171089651312qX   2171089652656qX   2171089653328qX   2171089655440qX   2171089655536qe.(       w
<�Q=Yٻ> f�<_ȿ9��>���;����ň���>����K��>���f����7?<�I�Z?���
-�T���.&�_��>�����t��"���P��:��O���=����9��P����!��f�%�A=Z����l���W��� �(       ջ��p)���? �¾;*?5 �p�);n�@�����%��k�=��?	>��>J�K�>��3Ί?�m�'��=z�����L��oc >(�"�(}���g?���`�^>*(�<��>��>Sk/>Q��>�E�>-�U�n>�0d?8�?ϳ�"%�(       �!��1�.�Z�=��>���T��<���l,�V�/�@֒���A��¿�=׬�>�[��_q�wF��
���-?�V�=�5n�H��Zv\�$�̿^���;��2�>��z�7��	�AK�7�F�����ֿ���>��'?L'&��LJ��b0>����(       ���u�>v)ؽ:�����$���z!���;C��^���J�>��>_�,?���3���A?��=�.�m��;����o>���>͔1�6�һ�?]����߾�m���
?���?�x�9TD?�U��Ӹ=�& ?�p�9�"��w޼���$��˨�@      �0�=��P�q�Ӿ�؏��Ai����< c�;�<]�)�%.ƽE'.�4��<%k��6��ʱ����f��H�W��9��zʽ�2H�"�N�b֞�@:��S��Iµ��zi���E�>��	���}<��<�<�I��R�=�b�ĸ��a+<�l�>wq��i��R�wAW��w�>o;H��Ȩ�{�b�ѠY�S�Q[B?�H>x��<|$پ�cz?���>Js>�I��8����^><�k���_��V4���]<�,?�ob���!��6L?Ȥ?t�̽ :���Ņ��P?H���MC�?B݋�+�G>5ׯ�$3u��v�?���>٩���=��]=��S�b7B�3�ǽ�����Aֳ�䰥���c\w��C���w�$Ԟ���z���T�@���k�}?���Z����B��
O>Rg3��#���ɖ��Fо�� ? ={<Ͽc6i�t�����=�Y���v?7��>�~=n��=?י?�ν�� ҽ�M�>���c־�@�������Lr�������$��;��>�:��k�̿��T�lb=�Ƙ���>���g�=B���V.�a����+�;��=�N=�皿��.��=��g�JI>�Q��@��<�ZM�+I�>}��"�<��0=P-�����E�;��m�����G���T�=K)��j�$�#�!J���=XNܾ��A�n�n�Ƥ>]Jf=��<U쥼����h�>��OX����>��!;pLQ��b�>U�G���ѽ՜�<Z��j�>1�Ͼ���?s,���t8�F;˾PPƾN:��"Q�=IZ�?���>�ª�:�p�Y>E�J��@:/�g�ʓ��o*��1�=޷K�8�>qQ��0�?1�=? ���۾����*��5T�;�]��b:�Ih��>�M���`��5jF?��x���޽,3����>t���"^���)�wSտ?I@<~4�=�~>L�I�����ڻ��7>3e�=g�$����=/O��sK��y��-�F�"��J�X�G�L�&�����El�:�+>؞=��>DwE���H=�f��O�y�H�e�w�7=�z�<�Ⴞ"������Ә������=<�=7鬽1$���A�>a�F�Kҽ1Y��-�(��H���f��L=`�"2��(�=�;J�`��<jB�=V�P=���=#s�����=���wv�����=~�=[����Z#�=y��<ʎ�<��=��=����A�= ��M�
�r=��ؽ`4������8Eν?ڽ ���[
ƽo)�|�-�A��}G�=`��\�}=z0=��=���<z>�P-�<0��= U���/ĽI$��eս0�q���(��`�+��:cJ3�e뮽<"��ɽ{���?D���什V��Vs��Q���Ѽv����#<I��@h
=�������>Ѵ��%uY����=Kl���������̩i=���}��������=*=���ٕ���=�ـ�C��>��'�K��>ka?9X4?�Ū�W�)�����hW)>�O��g=��9P�I�=&耾j<v����_�J?:�?���T�⍧=��+?��5=��K=Dʿ�hQ>
,ӼW�F>4{�>f��>���5cѽ�E����D�bq�ȼA��m>=���1N3��&���<��@=ozK>鸥�g^u=gx�`\<\�C�f��J0��<\��;p�f�=��=�ހ�s��<T�	=�G�=���%����7t�-�ɽ�I=׫�a㜾��=���[u���->;�F=�G�>��w�����}�0�س�.���������Δ�=�^�=@Ѭ���?hħ�P�e<r�B��==u�>�8�>W�ӿN�T;i�-�~=�ɾ��t
�>~���.E�����=���>"��%Pa������<�����y� y?�Z�����(�L����������W�eˍ=�=���=�V�<�-�=e]�=��>u�=���)Т��>>y����7���#��޽Gyý�=Y�2;��=;���'=�<�ʐ��y!=��	�dڦ���ֽó���=Lx�<�|��#
��;��O>%�[d�>~	������8����$��C��I��k�<�
�=��A�{�j�d!V�`̭=8?II��z�1�|�9��I���c�OE��w=�4�>�-�r��Sk>d�<F��>=����t��V�>� ��q��?�m�=?�"��4"������J�m( �1t�?���>Y<�5�>Ȱ�u����&�������A=,����q�_�Ӿ�aI>�Ȅ��â��⨿x�U�䎂�}�I=n�=��K�� �>mq��h���۾��ȾZ7��J��Wȿ;�d��>2�o4x���>�x������O��5�^?�fο
8���<�Ú��q�~�Oځ�P�J=&��������<P�����<��>P�����zƼ�;r�󐁼����� w=�l	���=kk̽�m��Q�=��=�8��<<�C����X;4�E���"��1�=\�3�.�ӽ�@r���)�2��=����C��p��h��=[!�$'y=�ǜ��;��*��M]Z��?���r�����XA&��9D������.U=��O�K`-?�?��f��:(�z���.>�?*��=�z���O���c��4 ��;��p�w���6?�ȥ��>��~$���-�>������]��)�>n��<l4m�'��契?O{��%S<��>�
��y��4�)���~��=�=�=�B߽F@�=�%�(�B�8?̼΢}��$��l`=D?X=�5�|9<4�&�_�=�*���9M�,6=����z�ν�[���X >���������\��.=j��=�ӽ�^m=*��<~�=̝���=�8��=��%�6B��<pY�n��(������?��G9��Z�=y4<�n����Ľ�{<�۽	}�_I���u&�*x�%C�=�M����R���$�;����2���)���>V�������u½H,-=��%�ڄ$�HP���m��1�ӼmcŽ�D|����=����gya�����K��<�K�=na̽8���2��=Q��	�J�d�i��S���>5%���X>T38�J��= .�=J�X<i+��p���|=��k���۽ �PE8=s\<c������� �=ht׽���M3���F��� �s��<�R�>0H��>�>*���=�4�=����t>ѳ�=�'s�,5�W�R?K�^ʾ��e=e`�>1�:���<=��W�r_�� �>6Z1>
���G�>��c>φ�����Ƒ�=�$�=�����H��O�<�a�Y�=,J�+�=�|�=�Sr��/I>-����>��>״����>rc��𰽉����2N�b=����+>�~1��i޿|c��v,8=��%�[�=���L?->a��>�.b��=��w>�3��xhm�Zuп�j)����=Z�d��o�=f��;9>F�=�&X?�5����=hJ~=�5�RQ��k�U;��=�꘾���� �=W�5ɼ
h�V�v�t��	߾|aٻ������Ǵ��=��8iȽ�I��$)>��U@<��I�����"�����g�����N���r���G�=�ƽ!�gj�>�������u+��-��fH��z�<
`?(W��V�)�{�=m|�=T��=�G>ة�=��V=�"9;��&��]��l�=�2���]�UP��ɽ�=n�޽hN�=�;�=4IӽP$��ua	��/d��%��Mm���^ݼ�k�� �=����j��=Z���>ɺ�@D�~��=a*�׹Ͻ�P���D!���)�Ė�=ʾ�=p�ٽ��[=��h���}�V��=�|�ص= 5��8&�<	4�>��P0��L���J�� D&�>�q���ٽb�/�����29�=�z�k�>��<��i�=�=�W�=���<"a����=�qv<�l=�'F�2�=o�@��p9� q�<��=$�=0�Y���� �<~��=5�9��%������p��)�Ⱦ쭌>K��>H��	��>�3R�g��<\��1H?gG#��P��Q~�;�1�
F>T��D0�	��zn7��Ó;�q4>�?C�ީ�?��=�V�=�X�>�(Ƚ��̍+�wd@�t�>5�����$�>�<z���ž_a$��9>��I�*k��>��bV�>L�L���Y�|��>��Z�����t�<�d�>\t=B�^>)˨�^̙�v�j>0����5Ͼh::���>�m���z6��+� 8?k�-�t��=��?�쿚.V�ɤ���RO?Š���}<�u����=]L�D�'=5<c�⣷�r�G��3��F3=:�Z:.�Dz<��os=T�Z>���SK���K��L�=�B�; `�<��ӽ�U==���F������d=�]���C>m�Լ��H�4��<�#<v��<V�=��������=ت�<ݛ�<�lj��<\ʁ=���V N�]s�ൡ���<���1����W�����<^5�(��<�#x=���R��k(�y�=' .���G=��޼1$:����.�=�g=]��iZ>�
0���4�O>�\e�s�n�Ű�j,߼E&�=gkP�)6�3���jn��� �!?V5�=�"!>�zv�yjo��˖�W!ż_*���5�$|o���A?�-N�@�5i��o=��_��w�ίվlV���s ��.�=�罡<̾��?ot��8��<u����=�	?���c1�=�3���>]��<m f�� \������Z>�e��u�<�`��o��C�w>��>��	?��9�j�>s �<)��Ҁ?��>��
��С����>bh��T��Ȏ#>�0�?R��>(��<������>⦹>%ѣ>�:=����0?9gs=ď�� ���=sϔ��[ƽ0?=��;=W����>ڌ"=ɨ=�֫�!󃽷���INݽ���>��W>��{����>���=�z�<O�p?w
�>��׾P�޽<:;>�<e���{t���r?�e?o�ǽg�&�w��>)�>;��>�!>l���{m?Q��=��>�Ȫ=��������0��p��=��9��W??���>���D�=aHN�����V��=�M�R>ᄚ��<oѽ=�>ڥ�G1�=-䕾�>8�=�_=�,��=�����!^=Z����o�<)S�(a<�Gr��P�����~>HzL=����!�>���>��ս�����{�>C��'�S��נ;�O��]Q����<Rkj>����_�'c�=_;�d㜽I�mR����<p�=�#�8?)�ʿ7>�׽��)��<�1�$���L�>���NZ���=�I����@=x�޿$�q>�N�<6Bս-O|>��b?���	>�w&?��3���HSA=�Ð�=�~��>�>��|�`b��g��.�<U@l���������Lv�C?�p��x�?�b���H���B�MH�=ӏ3>|�>:	�>���#�^�D���#�Ԑ�b��=��Ͼ�����=������?�C8? �F�������վ���+�=�A�N?&q�>������<�N���>AZ �������=�(i�ҏ��� Ѿ�9�=J��=a��9?��<b��W��؉��vI��E��<�Y������/�̊>����c��P��>�{e��t����M����v>N�H=��$�υѾ�Q?{V��ٕ�	��������-�>GjY�g�tX#��H���Y�o��\�[��&�H��><1�>���5 �?4��=eu�='p
��i�<��ҿhv<>�Ծdy�"�]��y�>ξ�m˾�?�?~6½�w��π �g��>F�<?6�F�_B->�$��q�$?�&����/�UW���#����L;оܬJ>m��@н��>�`2��5���нJ~
�0
�$(��H�a���սao�Q��bIپg�ݽ��>j~��:^��]��`S:=�ľ����s��d��d�Ͻ@���>�6n뾓�x���=���G�5>�<���Bμ��eF?�=����`�=����`Ľ��(��"�=�B5�P�<��߽&��Ʈ=1�X��ڴ���Q>d��x ܽ{��=�<`���E��I=��	�=����`D<;�P�����7Pܼ8�,���=J�����=�&\���=����� <vԧ�ѽ�w=g�=U���cڼ�n=�C��z]���6�=	�O��'a�
�����T��=������<\��U�F�$=�|�<
J8�����V���;�%�3��Dl+=���<>2�����v��=c1��C� � =d)�;�����.�5W��(=�y=e�"�K�1�o�x=$ݲ�       �ij�